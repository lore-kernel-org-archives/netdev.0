From: jamal <hadi@cyberus.ca>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Mon, 21 Oct 2002 09:10:29 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210210909250.17911-100000@shell.cyberus.ca>
References: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 21 Oct 2002, jamal wrote:

>
> Theres a 2419 patch that should work for you at:
> http://www.cyberus.ca/~hadi/tulip-2419-napi-nifd.gz
> Now if you wanna get adventorous why not pick:
> http://www.cyberus.ca/~hadi/tulip-feed.tgz

Make sure you turn off FEEDB in tulip.h (thats new stuff which
hasnt hit the press yet).

cheers,
jamal
