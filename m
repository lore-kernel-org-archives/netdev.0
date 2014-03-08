From: poma <pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
	dev_watchdog+0x276/0x280()
Date: Sun, 09 Mar 2014 00:30:14 +0100
Message-ID: <531BA806.4080509@gmail.com>
References: <530332B7.10909@gmail.com> <53043521.4060206@gmail.com>
	<5319059E.1010205@gmail.com> <5319F40F.4040304@gmail.com>
	<531A737E.4010200@gmail.com>
	<20140308123528.GA2052@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Mailing-List fedora-kernel <kernel-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>,
	Josh Boyer <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Justin M. Forbes" <jforbes-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Thomas Haller <thaller-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <kernel-bounces-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>
In-Reply-To: <20140308123528.GA2052-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
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

T24gMDguMDMuMjAxNCAxMzozNSwgRnJhbmNvaXMgUm9taWV1IHdyb3RlOgouLi4KPiBJdCBhcHBs
aWVzIGZpbmUgYWdhaW5zdCBiMDFkNGU2ODkzM2VjMjNlNDNiMTA0NmZhMzVkNTkzY2VmY2YzN2Qx
IGJ1dAo+IGEgYnVnIGhpZGVzIGJlaGluZCB0aGUgJ3N0YXJ0JyB2YXJpYWJsZS4gWW91IG1heSBy
ZXBsYWNlIGl0IHdpdGggdGhlCj4gcGF0Y2ggYmVsb3cuIFRoZSAibmV0aWZfaW5mbyguLi4sICJm
cmFncyAuLi4iIGRlYnVnIHN0YXRlbWVudCBpcyBub2lzeQo+IHdoZW4gZW5hYmxlZC4gRG9uJ3Qg
dXNlIGl0LgouLi4KCllvdSdyZSByaWdodCEKVGhhbmtzLgoKVGhlc2UgYXJlIHRoZSByZXN1bHRz
IHdpdGggeW91ciBwYXRjaDoKCi0gUlRMODExMHMgUlRMLTgxNjkgUzMgVEVTVCAmIHI4MTY5LVJU
TDgxMTBzLXhtaXQtdjIucGF0Y2gKaHR0cHM6Ly9idWd6aWxsYS5yZWRoYXQuY29tL2F0dGFjaG1l
bnQuY2dpP2lkPTg3MjI4NwoKLSByODE2OSBSVEw4MTEwcyBwYWNjaGV0dG8KaHR0cHM6Ly9idWd6
aWxsYS5yZWRoYXQuY29tL2F0dGFjaG1lbnQuY2dpP2lkPTg3MjI5OQpodHRwczovL2J1Z3ppbGxh
LnJlZGhhdC5jb20vYXR0YWNobWVudC5jZ2k/aWQ9ODcyMjk5JmFjdGlvbj1kaWZmCgoKcG9tYQoK
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmtlcm5lbCBt
YWlsaW5nIGxpc3QKa2VybmVsQGxpc3RzLmZlZG9yYXByb2plY3Qub3JnCmh0dHBzOi8vYWRtaW4u
ZmVkb3JhcHJvamVjdC5vcmcvbWFpbG1hbi9saXN0aW5mby9rZXJuZWw=
