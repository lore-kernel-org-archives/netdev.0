From: "Coelho, Luciano" <luciano.coelho@intel.com>
Subject: Re: [PATCH] iwlwifi:Fix incorrect fallthrough in switch statement
 in the function iwl_mvm_check_running_scans
Date: Thu, 8 Oct 2015 08:30:22 +0000
Message-ID: <1444293021.2899.46.camel@intel.com>
References: <1442967859-16347-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Spinadel, David" <david.spinadel@intel.com>,
	"Dreyfuss, Haim" <haim.dreyfuss@intel.com>,
	"Bondar, Alexander" <alexander.bondar@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Stern, Avraham" <avraham.stern@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "xerofoify@gmail.com" <xerofoify@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442967859-16347-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Content-ID: <C1F9D9CE4F5D6543830A6E17FD219424@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE1LTA5LTIyIGF0IDIwOjI0IC0wNDAwLCBOaWNob2xhcyBLcmF1c2Ugd3JvdGU6
DQo+IFRoaXMgZml4ZXMgaW5jb3JyZWN0IGZhbGx0aHJvdWdoIGluIHRoZSBzd2l0Y2ggc3RhdG1l
bnQgY2hlY2tpbmcNCj4gdGhlIHNjYW4gdHlwZSBwYXNzZWQgYnkgdGhlIGNhbGxlciB0byBpd2xf
bXZtX2NoZWNrX3J1bm5pbmdfc2NhbnMNCj4gZm9yIHRoZSBzd2l0Y2ggY2FzZSBJV0xfTVZNX1ND
QU5fU0NIRUQgdG8gcmV0dXJuIGRpcmVjdGx5IGFmdGVyDQo+IHRoZSBjYWxsIHRvIGl3bF9tdm1f
c2Nhbl9zdG9wIGluIG9yZGVyIHRvIGF2b2lkIGZhbGx0aHJvdWdoIGludG8NCj4gdGhlIG5leHQg
Y2FzZSBhbmQgaW5jb3JyZWN0bHkgcmV0dXJuIHplcm8gaW5kaWNhdGluZyBzdWNjZXNzIHRvDQo+
IHRoZSBjYWxsZXIgZXZlbiBpZiB0aGUgZnVuY3Rpb24gY2FsbCB0byBpd2xfbXZtX3NjYW5fc3Rv
cCBmYWlscy4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IE5pY2hvbGFzIEtyYXVzZSA8eGVyb2ZvaWZ5
QGdtYWlsLmNvbT4NCj4gLS0tDQoNCkFwcGxpZWQgdG8gb3VyIGludGVybmFsIHRyZWUgd2l0aCBh
IG1vZGlmaWVkIGNvbW1pdCBtZXNzYWdlLg0KDQpUaGFua3MhDQoNCi0tDQpMdWNhLg==
