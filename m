From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH 2.4.28-pre4-bk3] forcedeth: Gigabit ethernet support and
 media detection changes
Date: Sun, 17 Oct 2004 16:10:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41727D66.8070007@colorfullife.com>
References: <Pine.LNX.4.44.0410171216490.29815-100000@dbl.q-ag.de> <417277B7.8000705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, blazara@nvidia.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <417277B7.8000705@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

>
>> - module_param call changed to MODULE_PARM
>
>
> OK
>
Not true anymore - module_param was backported as well. I'll post an 
updated patch.

--
    Manfred
