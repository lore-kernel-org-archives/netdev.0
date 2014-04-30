From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: Allow tc changes in user namespaces
Date: Wed, 30 Apr 2014 08:48:35 -0700
Message-ID: <1398872915.29914.164.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398871543-8435-1-git-send-email-stgraber@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: =?ISO-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1398871543-8435-1-git-send-email-stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCAyMDE0LTA0LTMwIGF0IDExOjI1IC0wNDAwLCBTdMOpcGhhbmUgR3JhYmVyIHdyb3Rl
Ogo+IFRoaXMgc3dpdGNoZXMgYSBmZXcgcmVtYWluaW5nIGNhcGFibGUoQ0FQX05FVF9BRE1JTikg
dG8gbnNfY2FwYWJsZSBzbwo+IHRoYXQgcm9vdCBpbiBhIHVzZXIgbmFtZXNwYWNlIG1heSBzZXQg
dGMgcnVsZXMgaW5zaWRlIHRoYXQgbmFtZXNwYWNlLgo+IAo+IFNpZ25lZC1vZmYtYnk6IFN0w6lw
aGFuZSBHcmFiZXIgPHN0Z3JhYmVyQHVidW50dS5jb20+Cj4gQWNrZWQtYnk6IFNlcmdlIEUuIEhh
bGx5biA8c2VyZ2UuaGFsbHluQHVidW50dS5jb20+Cj4gQ2M6ICJFcmljIFcuIEJpZWRlcm1hbiIg
PGViaWVkZXJtQHhtaXNzaW9uLmNvbT4KPiBDYzogSmFtYWwgSGFkaSBTYWxpbSA8amhzQG1vamF0
YXR1LmNvbT4KPiBDYzogIkRhdmlkIFMuIE1pbGxlciIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+Cj4g
Cj4gLS0tCj4gIG5ldC9zY2hlZC9jbHNfYXBpLmMgfCAzICsrLQo+ICBuZXQvc2NoZWQvc2NoX2Fw
aS5jIHwgOCArKysrKy0tLQo+ICAyIGZpbGVzIGNoYW5nZWQsIDcgaW5zZXJ0aW9ucygrKSwgNCBk
ZWxldGlvbnMoLSkKCkFja2VkLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+
CgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFp
bmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpo
dHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWlu
ZXJz
