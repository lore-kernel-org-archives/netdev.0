From: "Mala Anand" <manand@us.ibm.com>
Subject: Re: [Lse-tech] Re: (RFC): SKB Initialization
Date: Mon, 26 Aug 2002 08:04:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <47608.8238218383$1030367780@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
   "Bill Hartner" <bhartner@us.ibm.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>>I think the skbinit patch and recycling skbs are mutually exclusive.

>I would say they are more orthogonal than mutually exclusive.
>Although ou still need to prove that relocating the code actually helps in
>real life. On paper it looks good.
Troy Wilson (who works with me) posted SPECweb99 results using my
skbinit patch to lkml on Friday:
 http://www.uwsg.iu.edu/hypermail/linux/kernel/0208.2/1470.html
I know you don't subscribe to lkml. Have you seen these results?
On Numa machine it showed around 3% improvement using SPECweb99.


Regards,
    Mala


   Mala Anand
   IBM Linux Technology Center - Kernel Performance
   E-mail:manand@us.ibm.com
   http://www-124.ibm.com/developerworks/opensource/linuxperf
   http://www-124.ibm.com/developerworks/projects/linuxperf
   Phone:838-8088; Tie-line:678-8088
