From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next v2] nlmon: use standard rtnetlink link api for
 add/del devices
Date: Tue, 02 Jul 2013 21:47:03 +0200
Message-ID: <51D32E37.4080905@redhat.com>
References: <1372755331-1267-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754961Ab3GBTrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 15:47:09 -0400
In-Reply-To: <1372755331-1267-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2013 10:55 AM, Jiri Pirko wrote:
> It is not nice when netdev is created right after module load and with
> some implicit name. So rather change nlmon to use standard rtnl link API.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
