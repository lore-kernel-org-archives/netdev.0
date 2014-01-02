From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26
 kernel
Date: Thu, 2 Jan 2014 18:27:04 +0000
Message-ID: <1388687224.9947.25.camel@bwh-desktop.uk.level5networks.com>
References: <CAMBtn_2fjONQk0aO6MBy3j9X__78CTon_aYzJWCjouKnZDXEMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Asi Lichtenstein <asili22@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50507 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbaABS1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:27:07 -0500
In-Reply-To: <CAMBtn_2fjONQk0aO6MBy3j9X__78CTon_aYzJWCjouKnZDXEMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 15:24 +0200, Asi Lichtenstein wrote:
> Hi there,
> 
> I need to add such support.
> How would you recommend me adding such support?
> 
> Is there a patch I could use?

There is a series of patches on ftp.kernel.org that you can use to
update from 2.6.16 to 3.12 or any version in between. :-)

Seriously, this list does not deal with development on such old kernel
versions.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
