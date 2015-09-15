From: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Subject: Re: [PATCH] Net: core: sock.c coding style fixes
Date: Tue, 15 Sep 2015 21:11:32 +0200
Message-ID: <55F86D64.1050003@vipserv.org>
References: <1442339925-17079-1-git-send-email-cristos@vipserv.org>
 <87mvwnbkzr.fsf@x220.int.ebiederm.org> <55F8652D.30809@vipserv.org>
 <20150915184346.GA7817@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sv1-2.x14.eu ([144.76.176.218]:50721 "EHLO sv1-2.x14.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555AbbIOTLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 15:11:34 -0400
In-Reply-To: <20150915184346.GA7817@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 200 checkpatch changes in one commit?
> 
> imo it makes sense to fix coding style only if nearby lines are
> affected by meaningful changes.
> Just blank rewrites like these are more harmful than useful.
> They distort git blame, make backporting harder, etc.

I'll keep that in mind, thank you.
