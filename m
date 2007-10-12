From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH][BNX2X] round three
Date: Fri, 12 Oct 2007 16:47:28 +0200
Message-ID: <p73641c4cfz.fsf@bingen.suse.de>
References: <1192038559.29746.127.camel@eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eliezer Tamir" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47201 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385AbXJLOrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 10:47:31 -0400
In-Reply-To: <1192038559.29746.127.camel@eliezer> (Eliezer Tamir's message of "Wed\, 10 Oct 2007 19\:49\:19 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Eliezer Tamir" <eliezert@broadcom.com> writes:


> * For now depend on x86 or x86_64, will add more architectures ASAP.

Why is that? Linux drivers normally should not be architecture specific.

-Andi
