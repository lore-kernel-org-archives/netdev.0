From: "=?ISO-8859-1?Q?Oliver_Pinter_(Pint=E9r_Oliv=E9r)?="
	<oliver.pntr@gmail.com>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 22:31:03 +0100
Message-ID: <6101e8c40801141331n3cb66c04pc74ff07faf04c8fd@mail.gmail.com>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com>
	 <20080114125200.28cb4c69@deepthought>
	 <20080114210105.GG9847@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gregkh@suse.de
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:45311 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbYANVbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 16:31:04 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2403681fga.17
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 13:31:03 -0800 (PST)
In-Reply-To: <20080114210105.GG9847@does.not.exist>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think, it is a potential security breakpoint, when applications with
root permission its read, then a machine is freezed, or only i thin
it's?


-- 
Thanks,
Oliver
