From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.8.1-mm4 11/11] r8169: vlan support
Date: Sat, 28 Aug 2004 19:21:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4131136E.9070702@pobox.com>
References: <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com> <20040823225335.GG20726@electric-eye.fr.zoreil.com> <20040823225505.GH20726@electric-eye.fr.zoreil.com> <20040823225620.GI20726@electric-eye.fr.zoreil.com> <20040823225713.GJ20726@electric-eye.fr.zoreil.com> <20040823225821.GK20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040823225821.GK20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

applied all 11 patches to netdev-2.6.

does this series of patches imply that a librealtek kernel module is 
coming soon?  There's an awful lot of code duplication (due to hardware 
similarties) in r8169, 8139cp, and 8139too.

	Jeff
