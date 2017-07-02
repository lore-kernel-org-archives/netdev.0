From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next v5 07/16] bpf: Add setsockopt helper function to
 bpf
Date: Sun, 2 Jul 2017 20:31:03 +0000
Message-ID: <A3A8A77C-A805-437D-A79D-3CD517FDD289@fb.com>
References: <20170630200706.4183158-8-brakmo@fb.com>
 <201707021447.jot6KTZQ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
        netdev <netdev@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        Blake Matheny <bmatheny@fb.com>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David Ahern" <dsa@cumulusnetworks.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54610 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751876AbdGBUbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2017 16:31:41 -0400
In-Reply-To: <201707021447.jot6KTZQ%fengguang.wu@intel.com>
Content-Language: en-US
Content-ID: <8CDF3FEC4AE4E74389F05D7A6ADA271D@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpPbiA3LzEvMTcsIDExOjUxIFBNLCAia2J1aWxkIHRlc3Qgcm9ib3QiIDxsa3BAaW50ZWwuY29t
PiB3cm90ZToNCg0KICAgIEhpIExhd3JlbmNlLA0KICAgIA0KICAgIFthdXRvIGJ1aWxkIHRlc3Qg
RVJST1Igb24gbmV0LW5leHQvbWFzdGVyXQ0KICAgIA0KICAgIHVybDogICAgaHR0cHM6Ly9naXRo
dWIuY29tLzBkYXktY2kvbGludXgvY29tbWl0cy9MYXdyZW5jZS1CcmFrbW8vYnBmLUFkZGluZy1z
dXBwb3J0LWZvci1zb2NrX29wcy8yMDE3MDcwMS0yMDMwMzkNCiAgICBjb25maWc6IHg4Nl82NC1y
YW5kY29uZmlnLWkwLTA3MDEwNDMwIChhdHRhY2hlZCBhcyAuY29uZmlnKQ0KICAgIGNvbXBpbGVy
OiBnY2MtNC45IChEZWJpYW4gNC45LjQtMikgNC45LjQNCiAgICByZXByb2R1Y2U6DQogICAgICAg
ICAgICAjIHNhdmUgdGhlIGF0dGFjaGVkIC5jb25maWcgdG8gbGludXggYnVpbGQgdHJlZQ0KICAg
ICAgICAgICAgbWFrZSBBUkNIPXg4Nl82NCANCiAgICANCiAgICBBbGwgZXJyb3JzIChuZXcgb25l
cyBwcmVmaXhlZCBieSA+Pik6DQogICAgDQogICAgICAgbmV0L2J1aWx0LWluLm86IEluIGZ1bmN0
aW9uIGBicGZfc2V0c29ja29wdCc6DQogICAgPj4gKC50ZXh0KzB4NWJiNjkpOiB1bmRlZmluZWQg
cmVmZXJlbmNlIHRvIGB0Y3Bfc2V0c29ja29wdCcNCg0KUGF0Y2gg4oCcYnBmOiBmaXggdG8gYnBm
X3NldHNvY2tvcHPigJ0gc3VibWl0dGVkLg0KICAgIA0KICAgIC0tLQ0KICAgIDAtREFZIGtlcm5l
bCB0ZXN0IGluZnJhc3RydWN0dXJlICAgICAgICAgICAgICAgIE9wZW4gU291cmNlIFRlY2hub2xv
Z3kgQ2VudGVyDQogICAgaHR0cHM6Ly91cmxkZWZlbnNlLnByb29mcG9pbnQuY29tL3YyL3VybD91
PWh0dHBzLTNBX19saXN0cy4wMS5vcmdfcGlwZXJtYWlsX2tidWlsZC0yRGFsbCZkPUR3SUJBZyZj
PTVWRDBSVHRObFRoM3ljZDQxYjNNVXcmcj1wcV9NcXZ6ZnktQzhsdGtneXgxdV9nJm09ZFo3Rnhi
amdvR0h4QW12MndmdFByLXlRVkU4RHJPM2ViRUV4emkzcEpZQSZzPVoxLVAtV21COFdXMVBXOHZH
Skx0cF9VS1VCYmdTOVI2WlFEOHAwZHUzWG8mZT0gICAgICAgICAgICAgICAgICAgIEludGVsIENv
cnBvcmF0aW9uDQogICAgDQoNCg==
