From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] refactor code and mark expected switch
 fall-throughs
Date: Wed, 01 Nov 2017 20:46:58 +0900 (KST)
Message-ID: <20171101.204658.787298649317439690.davem@davemloft.net>
References: <20171022203942.Horde.vHHdAHmZbpcBFTJEP0yIy9k@gator4166.hostgator.com>
        <cover.1509080630.git.garsilva@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ralf@linux-mips.org, wharms@bfs.de,
        hal@kd.net.au
To: garsilva@embeddedor.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cover.1509080630.git.garsilva@embeddedor.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Fri, 27 Oct 2017 00:50:57 -0500

> The aim of this patchset is firstly to refactor code in nr_route.c in order to make it
> easier to read and maintain and, secondly, to mark some expected switch fall-throughs
> in preparation to enabling -Wimplicit-fallthrough.
> 
> I have to mention that I did not implement any unit test.
> If someone has any suggestions on how I could test this piece of code
> it'd be greatly appreciated.

Series applied, thank you.
