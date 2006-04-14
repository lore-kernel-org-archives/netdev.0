From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 14 Apr 2006 15:42:40 -0700 (PDT)
Message-ID: <20060414.154240.30125561.davem@davemloft.net>
References: <444005DA.4090606@intel.com>
	<20060414.140225.113553109.davem@davemloft.net>
	<Pine.WNT.4.63.0604141527420.2116@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bb@kernelpanic.ru, herbert@gondor.apana.org.au,
	kernel@linuxace.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23730
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751294AbWDNWmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:42:54 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0604141527420.2116@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 15:32:55 -0700 (Pacific Daylight Time)

> well there was one of them here, but the tg3 bit may actually be due to 
> the 2.6.14 problems.
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=6279

There are 2 e1000 gigabit devices in that person's system, and
not one tg3 device.
