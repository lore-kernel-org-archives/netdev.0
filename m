From: Laudney Ren <laudney@21cn.com>
Subject: T/TCP for Linux Website Major Update Completed
Date: Mon, 1 Apr 2002 21:54:28 +0800
Sender: owner-netdev@oss.sgi.com
Message-ID: <200204011352.g31DqNv31317@oss.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
      charset="GB2312"
Content-Transfer-Encoding: 8bit
To: netdev <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hi, everyone:

   "T/TCP for Linux" has seen major updates during the last one month:

1) A new mirror site opened at http://ttcplinux.tripod.com
   The project home is still at http://ttcplinux.sourceforge.net

2) "Tools"
   a) Sock
      Sock is a network program written by W. Richard Stevens. It can
      be used both as a client and as a server and can send both TCP and
      UDP packets.

   b) TCPdump
      Tcpdump is originally written by Van Jacobson, Craig Leres and
      Steven McCanne, all of whom come from Lawrence Berkeley Laboratory.
      Tcpdump sets the network interfaces in "promiscuous" mode to sniff
      every packet received by the interfaces. Tcpdump-3.3 is able to
      print out CC, CC_NEW and CC_ECHO options introduced by T/TCP.

   c) SSH_tunnel
      SSH_tunnel is a perl script. If you are using ssh behind a firewall
      or a proxy, you can use this script to direct your ssh traffic through
      the proxy.

3) "Join us"
   If you are interested, you can join as an end-user, andience or developer.
   You will see how to do so on this page.

4) "Documents"
   This is the part that has seen most drastic updates. There have been about
   20 flowgraphs to outline TCP/IP stack in an easy manner or describe methods
   call sequence in details. You can browse the docs online or download a zipped
   version at http://prdownloads.sourceforge.net/ttcplinux/Docs_2_4_2.zip.
   All the documents are divided into six parts:

Part one: Linux Kernel TCP/IP Stack Analyses
   You will see everything, from mostly involved structures to all the methods
   called during the sending and receiving process and state transition graph,
   that are both important and foundamental. Anyone that is interested in the
   understanding of TCP/IP stack of Linux kernel can find useful information here.

Part two: Introduction to T/TCP defined in RFC 1644
   Here you see detailed introductions to T/TCP, eg. what modifications does T/TCP
   bring to standard TCP?

Part three: Design and Implementation Approach 
   This part is the longest one. It's about implementation approaches. Lies here the
   answer to "How T/TCP add new functions to TCP with being able to fall back to
   TCP automatically or manually?"

Part four: Known Problems with T/TCP defined in RFC 1644
   T/TCP has been around for some time. But it's been rejected for its serious security
   problems. A detailed breakdown of those problems and "crack methods" are described
   here. Maybe the biggest mission of "T/TCP for Linux" is to handle the security
   problems and come up with a new RFC. Of course, with the necessary involvement of
   each of you around.

Part five: Current Patches Performance Testing Information 
Part six: Current Patches Debugging and Fixing Information 
   These two parts are not started since the debugging process have yet started.Information
   will be updated lively on these two parts.

5) "Contact"
   If you have any comment or question, contact us. Email addresses can be found on
   the contact page. Or, simply post to our mailing lists and forum. We'll try the best
   to give instant replies.
