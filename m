From: Boian Bonev <boian@bonev.com>
Subject: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling), GRE Ethernet tunneling
Date: Sun, 13 Mar 2005 04:14:27 +0200
Message-ID: <20050313021427.26190.qmail@orange.bonev.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_1_1110680067_26188"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
To: Lennert Buytenhek <buytenh@wantstofly.org>,
        Pekka Savola <pekkas@netcore.fi>, jamal <hadi@cyberus.ca>,
        shemminger@osdl.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_1_1110680067_26188
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: quoted-printable


it really looks stoopid but i found your discussion on linux tunneling wh=
ile looking for replies to my post on GRE Ethernet tunneling - it was an =
ask for help :) and all we have walked the same path alone

seems you have concept proof on etherip encap and i did a gre like one
here is my dirty code: http://purple.bonev.com/ (it is made on 2.4.28, bu=
t i still use 2.4/e1000/bcm5700/no napi on my high load routers)

in rethinking tunnel creation and management - if i summarize all etherne=
t like devices shall be ARPHDR_ETHER, best user-kernel proto will be netl=
ink and also why not support ethtool for virtual ethernets? it will make =
it easier for userland to know what the heck kind of device it is at leas=
t

about interoperability - look here: http://www.mikrotik.com/Documentation=
/manual_2.7/Interface/EoIP.html

b.
--=_1_1110680067_26188--
