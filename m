From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 08 Feb 2017 09:27:22 -0800
Message-ID: <937450EB-BF9D-4963-B690-D6B58C8A197E@me.com>
References: <20170207140144.GA11233@localhost>
 <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
 <BBA8C11E-44DF-4693-957F-0354BEC75FC3@me.com>
 <20170208052746.GA1779@localhost.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:55290 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752061AbdBHR1x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:27:53 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL201600GGDXM00@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Wed, 08 Feb 2017 17:27:25 +0000 (GMT)
In-reply-to: <20170208052746.GA1779@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 07, 2017, at 21:27, Richard Cochran <richardcochran@gmail.com> =
wrote:
>=20
> On Tue, Feb 07, 2017 at 05:52:52PM -0800, Denny Page wrote:
>> Most, but not all. The TI DP83630 doesn=E2=80=99t support =
timestamping for all packets, but it does support either PTP or NTP:
>=20
> That is the one and only device that explicitly supports NTP. This is
> a nice idea, of course, but it just did not take off among other
> products.

With a commonly available NTP implementation supporting hardware =
timestamping, this might get a bit more traction with manufacturers.=20

Denny
