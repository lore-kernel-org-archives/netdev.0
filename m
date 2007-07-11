From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Wed, 11 Jul 2007 16:46:51 -0700
Message-ID: <08FE5CC30C9A3F41BF819A502CF7BF6E01A0644A@fmsmsx411.amr.corp.intel.com>
References: <20070708161154.GZ4146@rhun.haifa.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	<shemminger@linux-foundation.org>, <netdev@vger.kernel.org>
To: "Muli Ben-Yehuda" <muli@il.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55077 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935695AbXGKXqx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 19:46:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070708161154.GZ4146@rhun.haifa.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
Muli Ben-Yehuda wrote:
>> Net result:  zilch.  No performance increase, no noticeable CPU
>> utilization
>> benefits.  Nothing.  So I dropped it.
>
>Do you have pointers to the patches perchance?

Muli, I've been looking for this code and it looks like it's gone. 
I was using a Power5 system that I had borrowed and the folks I
borrowed it from have reformatted the drive.  I never bothered
to hang on to the patches because they were neither particularly
pretty or particularly useful.  Sorry.
-Mitch
