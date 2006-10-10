From: Paul Mackerras <paulus@samba.org>
Subject: Re: 2.6.19-rc1: known regressions (v3)
Date: Wed, 11 Oct 2006 08:58:45 +1000
Message-ID: <17708.9637.569670.824121@cargo.ozlabs.ibm.com>
References: <Pine.LNX.4.64.0610042017340.3952@g5.osdl.org>
	<20061010051019.GB3650@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: fastboot@osdl.org, alsa-devel@alsa-project.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Thierry Vignaud <tvignaud@mandriva.com>, discuss@x86-64.org,
   Trond Myklebust <Trond.Myklebust@netapp.com>,
   Alex Romosan <romosan@sycorax.lbl.gov>,
   Torsten Kaiser <kernel@bardioc.dyndns.org>, Olaf Hering <olaf@aepfle.de>,
   ak@suse.de, linuxppc-dev@ozlabs.org,
   Andrew de Quincey <adq_dvb@lidskialf.net>,
   Dave Kleikamp <shaggy@austin.ibm.com>, Jens Axboe <jens.axboe@oracle.com>,
   Sukadev Bhattiprolu <sukadev@us.ibm.com>, Antonino Daplas <adaplas@pol.net>,
   v4l-dvb-maintainer@linuxtv.org, perex@suse.cz,
   Linus Torvalds <torvalds@osdl.org>, linux-pm@osdl.org,
   linux-fbdev-devel@lists.sourceforge.net,
   linux-usb-devel@lists.sourceforge.net, linux-ide@vger.kernel.org,
   Steve Fox <drfickle@us.ibm.com>, netdev@vger.kernel.org,
   Greg Kroah-Hartman <gregkh
Return-path: <fastboot-bounces@lists.osdl.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061010051019.GB3650@stusta.de>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/fastboot>,
	<mailto:fastboot-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/fastboot>
List-Post: <mailto:fastboot@lists.osdl.org>
List-Help: <mailto:fastboot-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/fastboot>,
	<mailto:fastboot-request@lists.osdl.org?subject=subscribe>
Sender: fastboot-bounces@lists.osdl.org
Errors-To: fastboot-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Adrian Bunk writes:

> Subject    : sleep/wakeup on powerbooks apparently busted
> References : http://lkml.org/lkml/2006/10/5/13
> Submitter  : Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Handled-By : Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Status     : Benjamin will investigate

Should be fixed once Linus pulls the powerpc.git tree.

Paul.
