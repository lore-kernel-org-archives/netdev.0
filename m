From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/4] Add lightweight memory barriers fast_rmb() and
 fast_wmb()
Date: Tue, 18 Nov 2014 09:57:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F2930@AcuExch.aculab.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"michael@ellerman.id.au" <michael@ellerman.id.au>,
	"tony.luck@intel.com" <tony.luck@intel.com>,
	"torvalds@li
To: 'Alexander Duyck' <alexander.h.duyck@redhat.com>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141117171005.22333.96544.stgit@ahduyck-server>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFRoZXNlIHBhdGNoZXMgaW50cm9kdWNlIHR3byBuZXcg
cHJpbWl0aXZlcyBmb3Igc3luY2hyb25pemluZyBjYWNoZS1lbmFibGVkDQo+IG1lbW9yeSB3cml0
ZXMgYW5kIHJlYWRzLiAgVGhlc2UgdHdvIG5ldyBwcmltaXRpdmVzIGFyZToNCj4gDQo+IAlmYXN0
X3JtYigpDQo+IAlmYXN0X3dtYigpDQoNCk5vdCBzdXJlIEkgbGlrZSB0aGUgbmFtZXMuDQpJZiB0
aGUgYWltIGlzIHRvIHN5bmMgZGF0YSBpbnRvIHRoZSBsb2NhbCBjYWNoZSBzbyB0aGF0IGhhcmR3
YXJlDQp0aGF0IGlzIGRvaW5nIGNhY2hlLXNub29waW5nIGFjY2Vzc2VzIHNlZXMgdGhlIGRhdGEg
dGhlbiBtYXliZQ0KCWxvY2FsX3JtYigpIGFuZCBsb2NhbF93bWIoKQ0KDQpJSVJDIHJlYWRfYmFy
cmllcl9kZXBlbmRzKCkgaXMgYSBub3Agb24gZXZlcnl0aGluZyBleGNlcHQgYWxwaGEuDQpNYXli
ZSBhZGQgdGhlIGRlZmF1bHQgaWYgaXQgaXNuJ3QgZGVmaW5lZCBieSB0aGUgTUQgZmlsZT8NCg0K
CURhdmlkDQogDQo=
