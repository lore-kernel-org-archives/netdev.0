From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-drivers-2.6 2/9] ixgb: Fix unnecessary link state messages
Date: Sat, 18 Jun 2005 12:28:45 +0200
Message-ID: <20050618102845.GA25471@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.61.0506131234090.24260@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0506131234090.24260@anoushka.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Malli Chilakala <mallikarjuna.chilakala@intel.com> :
> Fix unnecessary link state messages
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
> Signed-off-by: John Ronciak <john.ronciak@intel.com>

The patch duplicates a lot of code. Do you really want these parts to be
modified independantly ?

--
Ueimor
