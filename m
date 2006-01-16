From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 18:02:19 -0500
Message-ID: <20060116230215.GE5529@tuxdriver.com>
References: <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org> <Pine.LNX.4.58.0601152038540.19953@irie> <20060116170951.GA8596@shaftnet.org> <Pine.LNX.4.58.0601162020260.17348@irie> <20060116190629.GB5529@tuxdriver.com> <1137450281.15553.87.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel.ortiz@nokia.com>,
	ext Stuffed Crust <pizza@shaftnet.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751258AbWAPXCr@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1137450281.15553.87.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2006 at 10:24:41PM +0000, Alan Cox wrote:

> I would expect equipment to honour the subset of configurations that
> meet BOTH the regulatory domain the system believes it exists within
> (which may change dynamically!) AND the AP advertisement.
> 
> If I have told my equipment to obey UK law I expect it to do so. If I
> hop on the train to France and forget to revise my configuration I'd
> prefer it also believed the APs

Yes, this is an excellent point.  I suppose this could result in
a non-functional configuration, but that is probably better than
conflicting w/ the local authorities... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
