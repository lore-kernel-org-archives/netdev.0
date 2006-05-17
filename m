From: Rick Jones <rick.jones2@hp.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Wed, 17 May 2006 11:52:41 -0700
Message-ID: <446B70F9.80707@hp.com>
References: <20060517182111.42939.qmail@web51510.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christopher Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:65419 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1750811AbWEQSwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 14:52:43 -0400
To: Benjamin Reed <br33d@yahoo.com>
In-Reply-To: <20060517182111.42939.qmail@web51510.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Reed wrote:
> In the case of lseek() and read(), you can use
> pread(). 

What is the meaning of the offset parameter of pread() for TCP or UDP etc?

rick jones
