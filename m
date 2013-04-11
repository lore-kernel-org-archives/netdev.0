From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: active URB submitted multiple times
Date: Wed, 10 Apr 2013 23:22:41 -0400 (EDT)
Message-ID: <20130410.232241.1038793023507666278.davem@davemloft.net>
References: <alpine.DEB.2.02.1304102354010.9358@fry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sarah.a.sharp@linux.intel.com
To: petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304102354010.9358@fry>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think you need to read Documentation/SubmittingPatches, and
Documentation/email-clients.txt

Do not submit the diff for the individual files seperately,
provide all the changes together as a single patch.

Do not use an attachment, instead provide your patch inline
as plain ASCII, unformatted text.
