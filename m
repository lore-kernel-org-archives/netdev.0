From: Colin Whittaker <colin.whittaker@heanet.ie>
Subject: MTU bug 2.6.8
Date: Tue, 15 Mar 2005 19:38:59 +0000
Message-ID: <20050315193858.GA32624@aine.heanet.ie>
Reply-To: Colin Whittaker <colin.whittaker@heanet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi David and the rest of the list.

I have hit a problem with MTUs under linux and the behaviour is
identical to that described in <http://content.ix2.net/arc/t-4645.html>

In this case I have a number of machines with e1000 and tg3 based gige
cards and they all exhibit this behaviour. 

I am running a stock 2.6.8.1 kernel and am more than happy to test any
fixes / patches but do not know the code base so finiding it is beyond
me.

If any more data is need please just ask.

regards,

Colin
-- 
Colin Whittaker    colin.whittaker@heanet.ie    Tel: +353 1 6609040
HEAnet NOC         noc@heanet.ie                iNOC-DBA:  1213*752
