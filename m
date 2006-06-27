From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 19/21] e1000: allow user to disable ich8 lock loss workaround
Date: Tue, 27 Jun 2006 07:21:44 -0700
Message-ID: <44A13EF8.4010909@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052048.25497.45771.stgit@gitlost.site> <44A08FFE.2050605@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59928 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S932270AbWF0OWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:22:03 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A08FFE.2050605@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> The workaround for the ich8 lock loss problem is only needed for
>> a very small amount of systems. This adds an option for the user
>> to disable the workaround.
> 
> Does "very small amount" equate to "never in real production machines"?

Unfortunately not.


Cheers,

Auke
