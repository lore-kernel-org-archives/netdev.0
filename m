From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Tue, 24 Mar 2009 14:28:01 +0100
Message-ID: <49C8DFE1.30607@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se> <49C8CCF4.5050104@cosmosbay.com> <OF0CA19511.F677CAFF-ONC1257583.0047FA24-C1257583.00494BDB@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33854 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbZCXN2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 09:28:09 -0400
In-Reply-To: <OF0CA19511.F677CAFF-ONC1257583.0047FA24-C1257583.00494BDB@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Eric Dumazet <dada1@cosmosbay.com> wrote on 24/03/2009 13:07:16:
>> [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
> 
> The patch fixes the problem and the system feels a bit more responsive 
> too, thanks.

Applied, thanks everyone.
