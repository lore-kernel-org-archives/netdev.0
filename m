From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Wed, 13 Oct 2004 11:29:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
References: <9625752b041012230068619e68@mail.gmail.com> <9625752b041013091772e26739@mail.gmail.com> <9625752b04101309182a96fbd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Danny <dannydaemonic@gmail.com>
In-Reply-To: <9625752b04101309182a96fbd2@mail.gmail.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can you confirm that you are running r8169 driver with NAPI and TSO turned on, 
along with Preemptable Kernel?  Also, I didn't see anything in the Oops 
specific to the r8169 driver, do you have another adapter available to run 
the same test on?  Finally, what is your setup (arch, # of cpus, etc)?

-- 
Jon Mason
jdmason@us.ibm.com
