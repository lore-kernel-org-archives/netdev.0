From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Thu, 1 Jun 2006 00:22:21 -0600
Message-ID: <20060601002221.B21730@openss7.org>
References: <20060531130615.GA32362@2ka.mipt.ru> <20060531122955.B10147@openss7.org> <20060601061234.GB28087@2ka.mipt.ru> <20060531.231839.10909081.davem@davemloft.net>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:59026 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S1751658AbWFAGWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 02:22:23 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060531.231839.10909081.davem@davemloft.net>; from davem@davemloft.net on Wed, May 31, 2006 at 11:18:39PM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,


On Wed, 31 May 2006, David Miller wrote:
> 
> Ok I believe you now :)
> 

I'll believe it if he interates through a subset and gets the
same results instead of using a pseudo-random number generator.

I thought you said you were considering jenkins_3word(), not
jenkins_2word()?
