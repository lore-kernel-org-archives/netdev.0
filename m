From: Patrick McHardy <kaber@trash.net>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Tue, 07 Dec 2004 07:35:06 +0100
Message-ID: <41B54F1A.6050905@trash.net>
References: <1102380430.6103.6.camel@buffy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261770AbULGGf3@vger.kernel.org>
To: Thomas Cataldo <tomc@compaqnet.fr>
In-Reply-To: <1102380430.6103.6.camel@buffy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Cataldo wrote:

>Hi,
>
>Tonight I upgraded to 2.6.10-rc3. Everything was fine until I started
>wondershaper to setup my Qos rules :
>
>wondershaper eth0 255 16
>
>And the machine freezed hard. No magic sysrq working, no oops in my
>logs.
>  
>
Please try to find out which line causes the lockup. Are you
using the same config options as with 2.6.9 ?

Regards
Patrick
