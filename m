From: poma <pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
	dev_watchdog+0x276/0x280()
Date: Sat, 08 Mar 2014 02:33:50 +0100
Message-ID: <531A737E.4010200@gmail.com>
References: <530332B7.10909@gmail.com> <53043521.4060206@gmail.com>
	<5319059E.1010205@gmail.com> <5319F40F.4040304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Intel Corporation <linux.nics-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mailing-List fedora-kernel <kernel-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>,
	Josh Boyer <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Justin M. Forbes" <jforbes-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Thomas Haller <thaller-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>
In-Reply-To: <5319F40F.4040304-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/options/kernel>,
	<mailto:kernel-request-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/kernel/>
List-Post: <mailto:kernel-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>
List-Help: <mailto:kernel-request-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/kernel>,
	<mailto:kernel-request-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org?subject=subscribe>
Sender: kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org
Errors-To: kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gMDcuMDMuMjAxNCAxNzozMCwgcG9tYSB3cm90ZToKPiBPbiAwNy4wMy4yMDE0IDAwOjMyLCBw
b21hIHdyb3RlOgo+PiAuLi4KPj4gQWZ0ZXIgYSBmZXcgZG96ZW4gdGVzdHMgd2l0aCB0aGUgdmFu
aWxsYSBjb21taXRzLCBhbmQgd2l0aCB0aGUgc2FtZQo+PiBhbW91bnQgb2YgcmF3aGlkZSBrZXJu
ZWxzIC4uLgo+PiBodHRwczovL2J1Z3ppbGxhLnJlZGhhdC5jb20vYXR0YWNobWVudC5jZ2k/aWQ9
ODcxNjk0Cj4+Cj4+IERhbiwgRnJhbmNvaXMgeW91IGFyZSBib3RoIHdlbGNvbWUgd2l0aCBjb21t
ZW50cyEKPj4gVGhhbmtzLgo+IAo+IFRob21hcyBVMi4gOikKPiAKPiBObyBiYXJraW5nIHctZG9n
LCBidXQgbm93IHRoZSBuZXR3b3JrIHRyYWZmaWMgaXMgdG90YWxseSBidXN0ZWQhCj4gaHR0cHM6
Ly9idWd6aWxsYS5yZWRoYXQuY29tL2F0dGFjaG1lbnQuY2dpP2lkPTg3MTk0Nwo+ICJwaW5nOiBz
ZW5kbXNnOiBObyBidWZmZXIgc3BhY2UgYXZhaWxhYmxlIC4uLiIKCkZyYW5jb2lzLCBkbyB5b3Ug
aGF2ZSB0aGlzWzFdIHBhdGNoIGFwcGxpY2FibGUgZm9yIHRoZSByZWNlbnQgJ3I4MTY5LmMnPwoK
JCBwYXRjaCAtcDUgPCByODE2OS14bWl0LnBhdGNoCnBhdGNoaW5nIGZpbGUgcjgxNjkuYwpIdW5r
ICMxIEZBSUxFRCBhdCA1ODcwLgpIdW5rICMyIHN1Y2NlZWRlZCBhdCA1NTQwIHdpdGggZnV6eiAy
IChvZmZzZXQgLTQ4MiBsaW5lcykuCkh1bmsgIzMgc3VjY2VlZGVkIGF0IDU2NDEgKG9mZnNldCAt
NDk0IGxpbmVzKS4KMSBvdXQgb2YgMyBodW5rcyBGQUlMRUQgLS0gc2F2aW5nIHJlamVjdHMgdG8g
ZmlsZSByODE2OS5jLnJlagoKCnBvbWEKCgpbMV0gaHR0cHM6Ly9idWd6aWxsYS5rZXJuZWwub3Jn
L2F0dGFjaG1lbnQuY2dpP2lkPTEyNTk2MQpodHRwczovL2J1Z3ppbGxhLmtlcm5lbC5vcmcvc2hv
d19idWcuY2dpP2lkPTE0OTYyI2MzNwoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCmtlcm5lbCBtYWlsaW5nIGxpc3QKa2VybmVsQGxpc3RzLmZlZG9yYXBy
b2plY3Qub3JnCmh0dHBzOi8vYWRtaW4uZmVkb3JhcHJvamVjdC5vcmcvbWFpbG1hbi9saXN0aW5m
by9rZXJuZWw=
