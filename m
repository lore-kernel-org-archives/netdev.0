From: Patrick McHardy <kaber@trash.net>
Subject: Re: [resend][PATCH] Introducing socket mark socket option
Date: Thu, 24 Jan 2008 10:43:48 +0100
Message-ID: <47985DD4.3000706@trash.net>
References: <47974D07.5040202@trash.net> <1201167495912-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1201167495912-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> A userspace program may wish to set the mark for each packets its send
> without using the netfilter MARK target. Changing the mark can be used
> for mark based routing without netfilter or for packet filtering.
> 
> It requires CAP_NET_ADMIN capability.


Looks good to me.
