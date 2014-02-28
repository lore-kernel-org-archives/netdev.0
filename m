From: Huang Shijie <b32955@freescale.com>
Subject: Re: change kmalloc into vmalloc for large memory allocations
Date: Fri, 28 Feb 2014 16:54:34 +0800
Message-ID: <53104ECA.4010702@freescale.com>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'perex@perex.cz'" <perex@perex.cz>,
 "'dmitry.torokhov@gmail.com'" <dmitry.torokhov@gmail.com>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'rostedt@goodmis.org'" <rostedt@goodmis.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'linux-arm-kernel@lists.infradead.org'"
 <linux-arm-kernel@lists.infradead.org>,
 "'gregkh@linuxfoundation.org
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

5LqOIDIwMTTlubQwMuaciDI45pelIDE2OjE1LCBXYW5nLCBZYWxpbiDlhpnpgZM6Cj4gY291bGQg
dGhpcyBtb2R1bGUgY2hhbmdlIHRoZSBtZW1vcnkgYWxsb2NhdGlvbiBpbnRvIHZtYWxsb2MgPwp0
aGUgYnVmZmVyIGFsbG9jYXRlZCBieSB2bWFsbG9jIGNhbiBub3QgYmUgdXNlZCBmb3IgdGhlIERN
QS4KCkkgdGhpbmsgdGhhdCdzIHdoeSBkcml2ZXJzIHVzZSB0aGUga21hbGxvYy4KCnRoYW5rcwpI
dWFuZyBTaGlqaWUKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpsaW51eC1hcm0ta2VybmVsIG1haWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3Rz
LmluZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5m
by9saW51eC1hcm0ta2VybmVsCg==
