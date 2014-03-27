From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH net-next v3 1/2] net: tcp_ipv6 do some cleanup
Date: Thu, 27 Mar 2014 09:18:37 +0800
Message-ID: <53337C6D.8050608@huawei.com>
References: <1395642322-9404-1-git-send-email-wangyufen@huawei.com> <20140326.154255.1270995413257461102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:29131 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaC0BS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:18:56 -0400
In-Reply-To: <20140326.154255.1270995413257461102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/27 3:42, David Miller wrote:
> From: Wangyufen <wangyufen@huawei.com>
> Date: Mon, 24 Mar 2014 14:25:21 +0800
> 
>> -static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
>> +static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
>>  				  int optlen)
> 
> If you change the first line, you must adjust the indentation of the second
> line so that "int optlen)" begins precisely at the first column after the
> openning parenthesis on the first line.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
ok, thanks
I'll send v4 later
