From: "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>
Subject: Re: change kmalloc into vmalloc for large memory allocations
Date: Mon, 3 Mar 2014 06:10:44 -0800
Message-ID: <20140303141044.GA9139@kroah.com>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <53104ECA.4010702@freescale.com>
 <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
 <20140228163304.GA15614@kroah.com>
 <35FD53F367049845BC99AC72306C23D102844605F38F@CNBJMBX05.corpusers.net>
 <20140303030821.GA16732@kroah.com>
 <35FD53F367049845BC99AC72306C23D102844605F390@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 'Will Deacon' <will.deacon@arm.com>, "'perex@perex.cz'" <perex@perex.cz>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'rusty@rustcorp.com.au'" <rusty@rustcorp.com.au>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'mschmidt@redhat.com'" <mschmidt@redhat.com>,
 "'rostedt@goodmis.org'" <rostedt@goodmis.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'linux-arm-kernel@lists.infradead
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D102844605F390@CNBJMBX05.corpusers.net>
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


On Mon, Mar 03, 2014 at 04:00:59PM +0800, Wang, Yalin wrote:
> Hi  greg,

Please read Documentation/SubmittingPatches for how to properly submit
kernel patches in a form that they could be accepted.

thanks,

greg k-h
