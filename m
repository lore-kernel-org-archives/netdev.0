From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH 2.6] fix zombie netlink socket in user space
Date: Sun, 19 Sep 2004 23:00:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414DF37A.4070508@eurodev.net>
References: <414D18EF.3080207@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <414D18EF.3080207@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira wrote:

> If you try to bind/connect to a non existant netlink socket, client 
> socket gets succesfully inserted as head in the socket list.


BTW oh please, forget this patch...

regards,
Pablo
