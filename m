From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Re. Please pull 'upstream' branch of wireless-2.6
Date: Wed, 8 Nov 2006 14:46:00 -0500
Message-ID: <20061108194554.GA25484@tuxdriver.com>
References: <6.1.1.1.2.20061108182728.02b11300@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:38409 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1753472AbWKHTq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 14:46:26 -0500
To: Roger While <simrw@sim-basis.de>
Content-Disposition: inline
In-Reply-To: <6.1.1.1.2.20061108182728.02b11300@192.168.6.12>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 08, 2006 at 06:27:54PM +0100, Roger While wrote:
> John, you just broke a considerable number of prism54 users.
> It is NOT an error if the MWI set fails. This is just a
> performance tweak and has NO effect on the driver working.

Yeah, looks like I was a bit overzealous on the warning squelch...

I'll cook-up a new patch that doesn't error-out.

John
-- 
John W. Linville
linville@tuxdriver.com
