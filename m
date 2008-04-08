From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 17:39:52 +0200
Message-ID: <7iy77o9wzb.fsf@lanthane.pps.jussieu.fr>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
	<873apwrc4t.fsf@basil.nowhere.org> <47FB60EF.1080004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:50433 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300AbYDHPnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 11:43:05 -0400
In-Reply-To: <47FB60EF.1080004@trash.net> (Patrick McHardy's message of "Tue\, 08 Apr 2008 14\:11\:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I think we have multiple qdiscs now doing very similar such hashes.
>> Any chance this could be factored out into a common library function
>> first?

> I'd suggest to use the flow classifier for this. For simplicity
> you could attach a default classifier that uses the same keys as
> this one.

I'm not sure I know what you're speaking about.  Could you please
point me at code somewhere?

                                        Juliusz
