From: Topher Fischer <javert42@cs.byu.edu>
Subject: Re: ARP Spoofing
Date: Wed, 02 May 2007 17:45:05 -0600
Message-ID: <46392281.8040909@cs.byu.edu>
References: <4638CDED.4020100@cs.byu.edu> <4638DEB9.90608@hp.com> <4638F6E8.3060609@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mead.cs.byu.edu ([128.187.80.29]:38320 "EHLO mail.cs.byu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767248AbXEBXko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 19:40:44 -0400
In-Reply-To: <4638F6E8.3060609@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Chris Friesen wrote:
> Vlad Yasevich wrote:
> 
>> If by arp spoofing you mean receiving arp replies from multiple
>> sources and
>> trusting all of them, then I haven't seen anything.
>>
>> I don't know the history as to why nothing has has been done.
> 
> This concept is a valuable tool to allow for fast publishing of IP
> address takeover in redundant-server situations.
> 
> There are ways in which it can be misused, but that doesn't make it an
> invalid technique.

I don't think it would be too difficult to preserve this kind of
functionality while improving security.  Is this really the only reason
why nothing has been done to protect machines from ARP spoofing?


- --
Topher Fischer
GnuPG Fingerprint: 3597 1B8D C7A5 C5AF 2E19  EFF5 2FC3 BE99 D123 6674
javert42@cs.byu.edu
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGOSKBL8O+mdEjZnQRAowZAJoCawbK1IM+TxBvAaNGtzdw5UrDmgCdGB5L
1mJdu4W61Opj+zqgtQJfdp8=
=qlBs
-----END PGP SIGNATURE-----
