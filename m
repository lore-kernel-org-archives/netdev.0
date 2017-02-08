From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 07 Feb 2017 21:48:42 -0800
Message-ID: <7A536474-7181-4C40-97C6-23F0D94FC90C@me.com>
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
Received: from st11p06im-asmtp002.me.com ([17.172.125.150]:54945 "EHLO
        st11p06im-asmtp002.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbdBHFsq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 00:48:46 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp002.me.com by
 st11p06im-asmtp002.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL100D00JOBM500@st11p06im-asmtp002.me.com> for netdev@vger.kernel.org;
 Wed, 08 Feb 2017 05:48:45 +0000 (GMT)
In-reply-to: <20170208052746.GA1779@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 07, 2017, at 21:27, Richard Cochran <richardcochran@gmail.com> =
wrote:
>=20
> On Tue, Feb 07, 2017 at 05:52:52PM -0800, Denny Page wrote:
>> Most, but not all. The TI DP83630 doesn=E2=80=99t support =
timestamping for all packets, but it does support either PTP or NTP:
>=20
> That is the one and only device that explicitly supports NTP. This is
> a nice idea, of course, but it just did not take off among other
> products.

I have to say I haven=E2=80=99t gone looking for others, and will take =
your word regarding the DP83630 being the one and only. I only learned =
about the DP83630 because I have a couple of stratum 1 devices that use =
this phy and have been working with the vendor regarding integration of =
hardware timestamps for NTP.

Denny
