From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch net-next-2.6 v3] net: consolidate and fix
 ethtool_ops->get_settings calling
Date: Tue, 6 Sep 2011 14:20:40 +0200
Message-ID: <20110906122040.GA25774@linux-mips.org>
References: <1314905304-16485-1-git-send-email-jpirko@redhat.com>
 <20110902122630.GC1991@minipsycho>
 <1314989161.3419.5.camel@bwh-desktop>
 <20110903133428.GA2821@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
        fubar@us.ibm.com, andy@greyhouse.net, kaber@trash.net,
        bprakash@broadcom.com, JBottomley@parallels.com,
        robert.w.love@intel.com, davem@davemloft.net,
        shemminger@linux-foundation.org, decot@google.com,
        mirq-linux@rere.qmqm.pl, alexander.h.duyck@intel.com,
        amit.salecha@qlogic.com, eric.dumazet@gmail.com,
        therbert@google.com, paulmck@linux.vnet.ibm.com,
        laijs@cn.fujitsu.com, xiaosuo@gmail.com, greearb@candelatech.com,
        loke.chetan@gmail.com, linux-mips@linux-mips.org,
        linux-scsi@vger.kernel.org, devel@open-fcoe.org,
        bridge@lists.linux-foundation.org
To: Jiri Pirko <jpirko@redhat.com>, tg@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20110903133428.GA2821@minipsycho>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 03, 2011 at 03:34:30PM +0200, Jiri Pirko wrote:

>  arch/mips/txx9/generic/setup_tx4939.c |    2 +-

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Feel free to merge this through the net tree.

  Ralf
