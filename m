From: Luciano Ruete <luciano.ruete@gmail.com>
Subject: [Announce] SequreISP an ISP's management software as GPL
Date: Tue, 07 Aug 2012 17:01:53 -0300
Message-ID: <50217431.2030501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: lartc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:53401 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444Ab2HGUDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 16:03:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is a one time announce.

 From about 12 years from now I (and my company) have worked with=20
small/medium ISPs or WISPs, always using Linux as the core router for=20
bandwidth management, QoS and load balancing.

As for 3 years from now we have started to work in a product now called=
=20
SequreISP[0], which is a final solution for small/medium ISPs, that now=
=20
is at a very stable state, and the proof is it's been used for more tha=
n=20
200 ISPs in more than 10 different countries worldwide[1].
With a range of clients up to 5000 per ISP, that is currently our mayor=
=20
success case (in a single server), but we think this can grow up to=20
10000 or 15000 as well.

SequreISP allows to do bandwidth management, QoS, load balancing=20
(current record is 40 ADSL lines in single server) and a lot more all=20
from a comfortable web interface (like a router) which is written in=20
Ruby on Rails. At a low level it generates tc(htb,sfq) queues and ip=20
ro/iptables commands.

SequreISP comes with a core which has all the technicals features, whic=
h=20
has been open sourced about more than a year ago with a AGPLv3 License.=
=20
You can check the project page at github[2]. As you can quickly verify,=
=20
the public repo has been keep up to date, with commits almost every day=
,=20
and that's because it is our main repo as well.

All user interface is fully available in English, Spanish and=20
Portuguese, as well as the in-line documentation.

There is also a commercial version of SequreISP, that comes with severa=
l=20
modules adding extra(administrative) functionalities like a invoicing=20
tools, notifications(via captive portal), videocahe, help desk, among=20
others.

We have a growing community of commercial SequreISP users, but=20
unfortunately there is no growing community from open source users and=20
developers as well. So this email is an open invitation for this to cha=
nge.

As a sysadmin and developer i can assure you that SequreISP solves a lo=
t=20
of complex problems with a neat and effective approach.

So if you are an ISP sysadmin or owner I really suggest you to give it =
a=20
try.

If you are also a developer you can contribute with the project and the=
=20
community, and you can even make money from this, ie. writing your own=20
plug-in and selling it to our existing client database (like in an app=20
store).

There is a lot of engineering and effort behind SequreISP and it is a=20
shame and a waste that a lot of people are not using it simply because=20
they don't know that it exists.

We are going to be also giving some SequreISP free conferences in=20
August, in Buenos Aires[3], S=E3o Paulo[4] and Budapest[5] (following=20
Ubiquiti World Conference scheduling, in order to ease access), so if=20
you're going to this Ubiquiti events, or simply like to know us,=20
consider yourself invited.

Thank you all for your time.


[0] http://sequreisp.com/?locale=3Den
[1] You can check our customers map at http://sequreisp.com/Map?locale=3D=
en
[2] https://github.com/sequre/sequreisp
[3] http://sequreisp.com/blog/posts/17?locale=3Des
[4] http://sequreisp.com/blog/posts/18?locale=3Dpt
[5] http://sequreisp.com/blog/posts/19?locale=3Den

--=20
Luciano Ruete
CTO - Sequre/SequreISP
Mitre 617 Piso 7 Ala Oeste
Mendoza - Argentina
http://www.sequreisp.com/
http://www.sequre.com.ar/
