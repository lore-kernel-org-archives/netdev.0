From: Ollie Wild <aaw@rincewind.tv>
Subject: Re: [PATCH] fix dst_entry leak in icmp_push_reply()
Date: Thu, 18 Aug 2005 12:05:31 -0700
Message-ID: <4304DBFB.5010906__46857.4443868876$1124392136$gmane$org@rincewind.tv>
References: <43039C3F.2000207@rincewind.tv> <4303CEC5.3010502@trash.net> <43042D94.4030303@rincewind.tv> <4304D763.4090001@rincewind.tv> <4304DA99.2080205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4304DA99.2080205@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

>Checking the return value of ip_append_data seems cleaner to me.
>Patch attached.
>  
>
Works for me.

Thanks,
Ollie
