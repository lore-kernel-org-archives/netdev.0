From: "Laudney Ren" <laudney@21cn.com>
Subject: T/TCP for Linux major update again.
Date: Sun, 19 May 2002 21:0:35 +0800
Sender: owner-netdev@oss.sgi.com
Message-ID: <RR979480794383.19193@receive10.inner-21cn.com>
Reply-To: laudney@21cn.com
Mime-Version: 1.0
Content-Type: text/plain;
      charset="GB2312"
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

T/TCP for Linux has seen major progress in the last 1.5 months:

1. Documents updated
Some core documents, including some graphs such as T/TCP sending
and receiving flowgraphs and T/TCP state transition graph, have
been carefully reviewed and modified.

2. Tools added
"SourceInsight" has been added to the downloadable tools list.
It's a Windows-based IDE especially suitable for complex projects
involving plenty of files and functions. It enables you to jump
directly from one variable to its type definition or from one
function to called functions within it. A lot of other features
prove incredibly useful.

3. First phase of debugging completed.
The patch for 2.4.2 has successfully gone through kernel compilcation.
The next phase of debugging will focus on function correctness based
on RFC1644. The codes will be released soon along with guidance
documents, so anyone interested can participate.


Any comment is welcomed at laudney@21cn.com

Laudney,
Admin of Sourceforge project T/TCP for Linux
