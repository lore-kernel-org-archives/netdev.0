From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 07 Oct 2014 16:18:32 -0400 (EDT)
Message-ID: <20141007.161832.453892039501955243.davem@davemloft.net>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412712996-4672-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue,  7 Oct 2014 22:16:36 +0200

> static values are automatically initialized to NULL
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Isn't there some implementation room given to compilers
as to the representation of true and false?
