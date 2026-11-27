#pragma once
// MinGW-w64 compatibility shims for the cross-compile toolchain.
// Windows SDK (MSVC) headers define everything below; old MinGW-w64 releases only forward-declare
// some WASAPI interfaces, which breaks code that activates or calls them.

#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>

#if defined(__MINGW32__) && !defined(__IAudioMeterInformation_INTERFACE_DEFINED__)
#define __IAudioMeterInformation_INTERFACE_DEFINED__
// Exact copy of the Windows SDK declaration (same IID and vtable order); only the endpoint peak
// meter is used by main.cpp.
MIDL_INTERFACE("C02216F6-8C67-4B5B-9D00-D008E73E0064")
IAudioMeterInformation : public IUnknown {
public:
    virtual HRESULT STDMETHODCALLTYPE GetPeakValue(float* pfPeak) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetMeteringChannelCount(UINT* pnChannelCount) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetChannelsPeakValues(UINT32 u32ChannelCount, float* afPeakValues) = 0;
    virtual HRESULT STDMETHODCALLTYPE QueryHardwareSupport(DWORD* pdwHardwareSupportMask) = 0;
};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(IAudioMeterInformation, 0xC02216F6, 0x8C67, 0x4B5B, 0x9D, 0x00, 0xD0, 0x08, 0xE7, 0x3E, 0x00, 0x64)
#endif
#endif
