From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: zero features for a vlan over bond
Date: Wed, 8 Apr 2009 01:16:24 +0300
Message-ID: <15ddcffd0904071516r119f89ccm343f62918b37b0a0@mail.gmail.com>
References: <Pine.LNX.4.64.0904061556140.32757@zuben.voltaire.com>
	 <6223.1239113811@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:4128 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759693AbZDGWQ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 18:16:26 -0400
Received: by fg-out-1718.google.com with SMTP id e12so1006721fga.17
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 15:16:24 -0700 (PDT)
In-Reply-To: <6223.1239113811@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 7, 2009 at 5:16 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> I suspect a bridge will display the same symptoms. I'm working on a p=
atch; I'll see
> what I can come up with. =A0Note, however, that at this writing, the =
set of drivers that
> explicitly supports VLAN passthrough (a non-zero vlan_features) is ra=
ther limited.

Hi Jay,

Thanks for your quick notes. I'm looking forward to see the patch and
then better understand the impact on bridges and how VLANs are going
along with bonds and bridges, but the way are later two coexist
peacefully? I remember discussions in the past whether one can bridge
bonds and/or bond bridges, however, I wasn't sure what was the
conclusion and what is possible, I would be more interested to see
that the specific case of a bond  connected to a bridge is supported.
We are going into the Passover vacation and as such I would be somehow
slow in responding over the next week or so.

Or.
