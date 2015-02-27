From: Joseph Salisbury <joseph.salisbury-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH][3.13.y-ckt][PATCH 0/1] Backport of mainline
	commit 4a46b24e for upstream 3.13.y-ckt.
Date: Fri, 27 Feb 2015 15:19:19 -0500
Message-ID: <cover.1424801573.git.joseph.salisbury__17156.3465301462$1425068398$gmane$org@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: kamal-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

QSBsYXJnZSBudW1iZXIgb2YgJ2ZhaWxlZCB0byBmbG93X2RlbCcgZXJyb3IgbWVzc2FnZXMgYXJl
IGJlaW5nIGxvZ2dlZCBpbiBPcGVuU3RhY2sgZGVwbG95bWVudHMgcnVubmluZyB0aGUgVWJ1bnR1
IFRydXN0eSByZWxlYXNlIHdpdGggdGhlIDMuMTMga2VybmVsLiBUaGlzIHdhcyBmaXhlZCB1cHN0
cmVhbSBpbiB0aGUgZGF0YXBhdGggZGttcyBtb2R1bGUgYXMgd2VsbCBhcyB0aGUgMy4xNiBrZXJu
ZWwuICAKCkNvbW1pdCA0YTQ2YjI0ZSBpcyB0aGUgZml4IGZvciB0aGlzIGlzc3VlLCBhbmQgaXMg
aW4gbWFpbmxpbmUgYXMgb2YgMy4xNi1yYzYuICBIb3dldmVyLCBjb21taXQgNGE0NmIyNGUgaGFz
IGEgZGVwZW5kZW5jeSBvbiBjb21taXQgNjYzZWZhMzYgZm9yIHRoZSBkZWZpbmUgb2YgcmN1X2Rl
cmVmZXJlbmNlX292c2wuCgpDb21taXQgNjYzZWZhMzYgaXMgYSBjbGVhbiBjaGVycnktcGljayBp
biB1cHN0cmVhbSAzLjEzLnktY2t0LiAgSG93ZXZlciwgNGE0NmIyNGUgcmVxdWlyZWQgYSBiYWNr
cG9ydC4gIFBsZWFzZSBjb25zaWRlciBpbmNsdWRpbmcgbWFpbmxpbmUgY29tbWl0IDY2M2VmYTM2
IGFuZCB0aGUgYmFja3BvcnRlZCB2ZXJzaW9uIG9mIDRhNDZiMjRlIGluIHRoZSBuZXh0IHYzLjEz
LnktY2t0IHJlbGVhc2UuCgpUaGUgYmFja3BvcnQgZm9yIHVwc3RyZWFtIHN0YWJsZSAzLjE0Lnkg
aXMgZGlmZmVyZW50IHRoYW4gZm9yIDMuMTMueS1ja3QgYW5kIEknbSBub3Qgc3VyZSBpZiB0aGlz
IGJ1ZyBleGlzdHMgaW4gdXBzdHJlYW0gMy4xNC4gIEkgY2FuIHNlbmQgdGhhdCBiYWNrcG9ydCBz
ZXBhcmF0ZWx5IGlmIG5lZWRlZC4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9v
cGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
