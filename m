From: David Miller <davem@davemloft.net>
Subject: Re: kenel level packet capturing
Date: Tue, 13 Dec 2011 13:36:29 -0500 (EST)
Message-ID: <20111213.133629.1213042365300662857.davem@davemloft.net>
References: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
	<20111019123733.GA21324@synalogic.ca>
	<CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: raviraj.j1991@gmail.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: raviraj joshi <raviraj.j1991@gmail.com>
Date: Tue, 13 Dec 2011 17:34:22 +0530

> We have decided to use PF_RING(a kernel module to capture packets) for
> the same due to the number of advantages.

What "advantages"?  The AF_PACKET socket layer already upstream in the
kernel supports every relevant performance feature PF_RING does, and
then some.
