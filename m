From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 19/21] e1000: allow user to disable ich8 lock loss workaround
Date: Mon, 26 Jun 2006 21:55:10 -0400
Message-ID: <44A08FFE.2050605@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052048.25497.45771.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56532 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030608AbWF0BzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:55:12 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052048.25497.45771.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> The workaround for the ich8 lock loss problem is only needed for
> a very small amount of systems. This adds an option for the user
> to disable the workaround.

Does "very small amount" equate to "never in real production machines"?


