From: Xiao Jiang <jgq516@gmail.com>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Thu, 17 May 2012 16:06:34 +0800
Message-ID: <4FB4B18A.8020803@gmail.com>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com> <4FB3A74E.4060303@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FB3A74E.4060303@mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov wrote:
> Hello.
>
> On 16-05-2012 12:01, jgq516@gmail.com wrote:
>
>> From: Xiao Jiang<jgq516@gmail.com>
>
>> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devices
>
>    Please also specify that commit's summary in parens.
Thanks, will add the summary if this patch does make sense.

Regards,
Xiao
>
>> which possibly use "usb%d" names, add this flag to make sure pandaboard
>> can mount nfs with smsc95xx NIC.
>
>> Signed-off-by: Xiao Jiang<jgq516@gmail.com>
>
> WBR, Sergei
