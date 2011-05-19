From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: packet received in a wrong rx-queue?
Date: Wed, 18 May 2011 18:26:07 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114@MILEXCH2.ds.jdsu.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D748939@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114MILEXCH2dsjds_"
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:44919 "HELO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751188Ab1ESBbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 21:31:39 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D748939@MILEXCH2.ds.jdsu.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114MILEXCH2dsjds_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Anyone can help to check the traffic file?

Thanks
jon

> -----Original Message-----
> From: Jon Zhou [mailto:Jon.Zhou@jdsu.com]
> Sent: Wednesday, May 18, 2011 5:01 PM
> To: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Subject: [E1000-devel] packet received in a wrong rx-queue?
>=20
> There are 2 packets in the traffic
>=20
> #1 create PDP context request, IPV4--UDP--GTP, src_ip=3DA and
> dst_ip=3DB,src_port=3DC,dst_port=3DD
>=20
> #2 create PDP context response, IPV4--UDP--GTP,src_ip=3DB, dst_ip=3DA,
> src_port=3DD,dst_port=3DC
>=20
> I suppose both of them will be received in same rx-queue but actually
> it doesn't
> Anything need to check?
>=20
> ethtool -i eth5
> driver: ixgbe
> version: 3.3.9-NAPI
> firmware-version: 0.9-3
> bus-info: 0000:08:00.1
>=20
> regards
> jon
>=20
>=20
>=20
>=20
>=20
> -----------------------------------------------------------------------
> -------
> What Every C/C++ and Fortran developer Should Know!
> Read this article and learn how Intel has extended the reach of its
> next-generation tools to help Windows* and Linux* C/C++ and Fortran
> developers boost performance applications - including clusters.
> http://p.sf.net/sfu/intel-dev2devmay
> _______________________________________________
> E1000-devel mailing list
> E1000-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/e1000-devel
> To learn more about Intel&#174; Ethernet, visit
> http://communities.intel.com/community/wired

--_002_4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114MILEXCH2dsjds_
Content-Type: application/octet-stream;
	name="UpdatePdpContextTransaction12-WithCreatePdpDeletePdp.pcap"
Content-Description: UpdatePdpContextTransaction12-WithCreatePdpDeletePdp.pcap
Content-Disposition: attachment;
	filename="UpdatePdpContextTransaction12-WithCreatePdpDeletePdp.pcap";
	size=1187; creation-date="Wed, 18 May 2011 00:55:01 GMT";
	modification-date="Tue, 17 May 2011 23:32:54 GMT"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAA0VFaTXVPAADbAAAA2wAAAAAdtfAIAAAdcXPAQAgARQAA
yQAAQAA+EZ3D2db1UdnW9WGFgQhLALWyvjIQAKUAAAAABEsAAAJCAGEQkFFx9ANC8FD//v8O8A/8
ECqWviARKpa9oBQFGgAAgAAC8SGDABAGb25saW5lBXRlbGlhAnNlhAAdgMAjBgEBAAYAAIAhEAEB
ABCBBgAAAACDBgAAAACFAATZ1vVRhQAE2db1UoYAB5FkJ0JyVPGHAAwBG4Efc5Zoh3SDEECXAAEB
mAAIAULwUAA0FguZAAJAAJoACBAiRgBygIOQ1Ye8qNJRWk0LkwgAjAAAAIwAAAAAHXFzwEAAHbXw
CAAIAEUAAHpEqQAAPxGYadnW9WHZ1vVRCEuFgQBmW64yEQBWKpa9oARLAAABgAj+DlYQbI/HRRFs
j8dAf27sHXeAAAbxIV/DdHqEABSAgCEQAwEAEIEGw0PHEoMGw0PHE4UABNnW9WSFAATZ1vV1hwAM
ARuBH3OWaId0gxBA1h97ldRRWk3edwcAgwAAAIMAAAAAHbXwCAAAHXFzwEAIAEUAAHEAAEAAPhGe
GNnW9VHZ1vVkhYEISwBd5S4yEgBNbI/HQAStAAADQvBQ//7/DvAQAAB+lxQFhQAE2db1UYUABFvI
mQ6HAAwBG4Efc5Zoh3SDEECUAAEQlwABAZgACAFC8FAANBYLmQACQAC2AAEBAfrRutRRWk2AvwcA
ZQAAAGUAAAAAHXFzwEAAHbXwCAAIAEUAAFNITgAAPxGU6NnW9WTZ1vVRCEuFgQA/7qMyEwAvKpa9
oAStAAABgA5WEGyPx0V/buwdd4UABNnW9WSFAATZ1vV1hwAMARuBH3OWaId0gxBACVY/FtlRWk0s
DwsAdgAAAHYAAAAAHbXwCAAAHXFzwEAIAEVIAGRUuwAAPBFlY1vImQ7Z1vV1BAMIaABQqI8w/wBA
bI/HRUUAAEBcAkAAQAYABV/DdHoR+vh5+ioBu9IX6o8AAAAAsAL///4KAAACBAWCAQMDAgEBCAoN
7pP6AAAAAAQCAAC7NXvz2VFaTb79DQB2AAAAdgAAAAAdtfAIAAAdcXPAQAgARUgAZFU4AAA8EWTm
W8iZDtnW9XUEAwhoAFCojzD/AEBsj8dFRQAAQMNsQABABpiaX8N0ehH6+Hn6LQG7CVy33AAAAACw
Av//+XYAAAIEBYIBAwMCAQEICg3uk/oAAAAABAIAACPWsYXaUVpNZ1cAAEAAAABAAAAAAB218AgA
AB1xc8BACABFAAAsAABAAD4Rnl3Z1vVR2db1ZIWBCEsAGEBpMhQACGyPx0AFNAAAE/8UBQAANtq1
1NtRWk23lQsAQAAAAEAAAAAAHXFzwEAAHbXwCAAIAEUAACxPpQAAPxGNuNnW9WTZ1vVRCEsISwAY
oxAyFAAIKpa9oGtcAAAT/xQFAACIcDsd21FaTQmwCwBAAAAAQAAAAAAdtfAIAAAdcXPAQAgARQAA
KgAAQAA+EZ5f2db1UdnW9WQISwhLABZ+ADIVAAZsj8dAa1wAAAGAAAAAABKgQJI=

--_002_4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114MILEXCH2dsjds_--
