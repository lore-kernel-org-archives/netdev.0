From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.9-rc2 1/1] r8169: default on disabling PCIDAC
Date: Mon, 20 Sep 2004 21:02:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920190252.GA16429@electric-eye.fr.zoreil.com>
References: <20040919224102.GA32577@electric-eye.fr.zoreil.com> <414F1DFD.9030008@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans-Frieder Vogt <hfvogt@arcor.de>, Andy Lutomirski <luto@myrealbox.com>,
        Jon Mason <jdmason@us.ibm.com>,
        Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <414F1DFD.9030008@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> Can this interrupt be used at runtime to detect that DAC isn't working?

Experiment suggests that. 

Errr... Do you really want to hot-reinit the device ?

--
Ueimor
