From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Thu, 22 Oct 2009 00:32:45 -0400
Message-ID: <20091022003245.5cd4885c.billfink@mindspring.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
	<1256115421-12714-9-git-send-email-gilad@codefidence.com>
	<4ADED6FA.2030502@gmail.com>
	<4ADEE119.7020803@codefidence.com>
	<4ADF616B.1090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:37170 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751263AbZJVEck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 00:32:40 -0400
In-Reply-To: <4ADF616B.1090405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Oct 2009, William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
> > I have no issue with leaving those, if everyone thinks we're better off.
> > 
> > BTW, while we're talking about OS envy, I do believe that Windows do let
> > you specify on a per route basis. Not that this is really a good ground for
> > technical decision, but still... :-)
> > 
> I'm not concerned with "envy", I'm concerned with training operators, and
> consistency across platforms.
> 
> I'm in favor of per route configuration, it seems reasonably clean, as
> long as it's done consistently with other systems.  I don't permit Windows
> systems to be used here (except under controlled security circumstances), so
> I'm not familiar with their configuration.  However, doing things similarly
> across platforms will ease documentation and training.

And as mentioned previously, the global options can be quite useful
in certain test scenarios.  I also agree the per route settings are
a very useful addition.  I think the global and per route settings
are complementary and shouldn't be thought of as in conflict with
one another.

						-Bill
