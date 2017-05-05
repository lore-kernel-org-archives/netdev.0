From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Fri, 5 May 2017 11:57:39 +0200
Message-ID: <20170505095739.GB6762@lst.de>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
 <CAPcyv4jzD0MEBRNTwTokVzgdDWas682ArUjRAGT1hp=QRE8Pjg@mail.gmail.com>
 <CAOQ4uxjha8_2_HwgdgBN=G-vNytAW5Gk155E9z8OWyFiGNEZVw@mail.gmail.com>
 <1493976265.30052.21.camel@linux.intel.com>
 <CAOQ4uxjErce01+xyDnM=nCJS+avQ4g6hQVvH3fVotj7Ws2moCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>,
 Liam Girdwood <lgirdwood@gmail.com>, linux-pci@vger.kernel.org,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Benjamin Tissoires <benjamin.tissoires@redhat.com>,
 Christoph Hellwig <hch@lst.de>, Joerg Roedel <joro@8bytes.org>,
 Linux ACPI <linux-acpi@vger.kernel.org>, tpmdd-devel@lists.sourceforge.net,
 Ben Skeggs <bskeggs@redhat.com>, nouveau@lists.freedesktop.org,
 linux-mmc@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Borislav Petkov <bp@suse.de>, Yisen Zhuang <yisen.zhuang@huawei.com>,
 Mathias Nyman <mathias.nyman@intel.com>, intel-gfx@lists.freedesktop.org,
 linux-input@vger.kernel.org, Mark Brown <broonie@kernel.org>,
 Bjorn Helgaas <bhelgaas@google.com>, Dan Williams <dan.j.williams@intel.com>,
 Andy Shevchenko <andriy.shevchenko@linux.intel
To: Amir Goldstein <amir73il@gmail.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjErce01+xyDnM=nCJS+avQ4g6hQVvH3fVotj7Ws2moCQ@mail.gmail.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gRnJpLCBNYXkgMDUsIDIwMTcgYXQgMTI6NTA6MzFQTSArMDMwMCwgQW1pciBHb2xkc3RlaW4g
d3JvdGU6Cj4gVG8gY29tcGxldGUgdGhlIHBpY3R1cmUgZm9yIGZvbGtzIG5vdCBjYydlZCBvbiBt
eSBwYXRjaGVzLAo+IHhmcyB1c2UgY2FzZSBzdWdnZXN0cyB0aGVyZSBpcyBhbHNvIGp1c3RpZmlj
YXRpb24gZm9yIHRoZSBhZGRpdGlvbmFsIGhlbHBlcnM6Cj4gCj4gdXVpZF9pc19udWxsKCkgLyB1
dWlkX2VxdWFsKCkKPiBndWlkX2lzX251bGwoKSAvIGd1aWRfZXF1YWwoKQoKVGhlIGlzX251bGwg
aXMgdXNlZnVsIGFuZCBJIGJldCB3ZSdsbCBmaW5kIG90aGVyIGluc3RhbmNlcy4gIEknbQpub3Qg
c3VyZSBfZXF1YWxzIHJlYWxseSBhZGRzIG11Y2ggdmFsdWUgb3ZlciB0aGUgZXhpc3RpbmcgX2Nt
cApoZWxwZXJzLCBidXQgb24gdGhlIG90aGVyIGhhbmQgdGhleSBhcmUgc28gdHJpdmlhbCB0aGF0
IHdlIG1pZ2h0IGFzCndlbGwgYWRkIHRoZW0uCgpUaGUgb3RoZXIgdGhpbmcgWEZTIGhhcyBpcyB1
dWlkX2NvcHkuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
CkludGVsLWdmeCBtYWlsaW5nIGxpc3QKSW50ZWwtZ2Z4QGxpc3RzLmZyZWVkZXNrdG9wLm9yZwpo
dHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2ludGVsLWdmeAo=
