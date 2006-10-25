From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Wed, 25 Oct 2006 13:18:27 -0700
Message-ID: <453FC693.10705@intel.com>
References: <453F9D4A.8090306@users.sourceforge.net> <20061025185656.GA19037@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anders Grafstrom <grfstrm@users.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55632 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S965227AbWJYUU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 16:20:27 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061025185656.GA19037@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Anders Grafstrom <grfstrm@users.sourceforge.net> :
> [...]
>> I'm thinking something like this patch.
> 
> I do not have the spec for the max duration at hand but it makes sense.
> 
> Can you:
> - decrease the duration of each sleep and increase the count of iterations
> - put the break on a line of its own
> - add a Signed-off-by: Foo Bar <baz@nit.fol> line
> - Cc: jeff@garzik.org and Auke Kok <auke-jan.h.kok@intel.com>

I'm already checking out specs, which, for 8255x devices, are available on 
http://e1000.sf.net/ .

Auke
